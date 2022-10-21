import React, { useState, useEffect, useRef } from 'react'
import {
    Button,
    Center,
    Table,
    Thead,
    Tbody,
    Tr,
    Th,
    Td,
    TableCaption,
    Text,
    HStack,
    VStack,
    Flex,
    Spinner,
    ScaleFade,
    Input,
    Link,
    useDisclosure,

} from "@chakra-ui/react"

import { Formik, Form, } from 'formik'
import { getScanReportTable, getScanReportFieldValues, useGet } from '../api/values'
import { set_pagination_variables } from '../api/pagination_helpers'
import ConceptTag from './ConceptTag'
import ToastAlert from './ToastAlert'
import PageHeading from './PageHeading'
import CCBreadcrumbBar from './CCBreadcrumbBar'
import Error404 from '../views/Error404'
import Pagination from 'react-js-pagination'


const FieldsTbl = (props) => {
    // get the value to use to query the fields endpoint from the page url
    const pathArray = window.location.pathname.split("/")
    const scanReportId = pathArray[pathArray.length - 4]
    // const scanReportTableId = pathArray[pathArray.length - 1]
    // const scanReportTableId = window.pk ? window.pk : parseInt(new URLSearchParams(window.location.search).get("search"))
    const scanReportTableId = parseInt(new URLSearchParams(window.location.search).get("search")) ?
        parseInt(new URLSearchParams(window.location.search).get("search")) : pathArray[pathArray.length - 2]
    const [alert, setAlert] = useState({ hidden: true, title: '', description: '', status: 'error' });
    const { isOpen, onOpen, onClose } = useDisclosure()
    const [values, setValues] = useState([]);
    const [error, setError] = useState(undefined);
    const [loading, setLoading] = useState(true);
    const [loadingMessage, setLoadingMessage] = useState("");
    const valuesRef = useRef([]);
    const scanReportTable = useRef([]);
    const scanReportName = useRef([]);
    const [mappingButtonDisabled, setMappingButtonDisabled] = useState(true);
    const [page_size, set_page_size] = useState(10)
    const [currentPage, setCurrentPage] = useState(1);
    const [totalItemsCount, setTotalItemsCount] = useState(null);
    const [firstLoad, setFirstLoad] = useState(true);

    useEffect(async () => {
        console.log('6', pathArray[pathArray.length - 6])
        console.log('5', pathArray[pathArray.length - 5])
        console.log('4', pathArray[pathArray.length - 4])
        // run on initial render
        props.setTitle(null)
        // get scan report name for breadcrumbs
        useGet(`/scanreports/${scanReportId}/`).then(sr => scanReportName.current = sr.dataset)

        let { local_page, local_page_size } = await set_pagination_variables(window.location.search, page_size, set_page_size, currentPage, setCurrentPage);
        window.history.pushState({}, '', `/scanreports/${scanReportId}/tables/${scanReportTableId}/?p=${local_page}&page_size=${local_page_size}`)

        setFirstLoad(false)
    }, []);


    useEffect(async () => {
    // if not the first load, then load data etc. This clause avoids an initial call using the default values of
        // currentPage and page_size, which is not desired.
        if (!firstLoad) {
            try {

                // Check if user can see SR table
                useGet(`/scanreporttables/${scanReportTableId}/`)

                const setValuesAsync = async (vals) => {
                    setValues(vals)
                }
                // get field table values for specified id
                getScanReportFieldValues(scanReportTableId, valuesRef, currentPage, page_size).then(val => {
                    setValuesAsync(val)
                    setTotalItemsCount(val.count)
                    setLoading(false)
                })

                // get scan report table data to use for checking person id and date event
                getScanReportTable(scanReportTableId).then(table => {
                    scanReportTable.current = table
                    setMappingButtonDisabled(false)
                })

                setLoading(false);
                setLoadingMessage("");
            }
            catch (error) {
                setLoading(false);
                setLoadingMessage("");
                setError("An error has occurred while fetching the fields")
            }
        }
    }, [currentPage, page_size, firstLoad]);

    const onPageChange = (page) => {
        window.history.pushState({}, '', `/scanreports/${scanReportId}/tables/${scanReportTableId}/?p=${page}&page_size=${page_size}`)
        setCurrentPage(page)
    }

    // called to submit a concept to be added. Calls handle submit function from app.js
    const handleSubmit = (id, concept) => {
        props.handleSubmit(id, concept, valuesRef, setValues, setAlert, onOpen, scanReportTable.current, 15)
    }

    // called to delete a concept. Calls handle delete function from app.js
    const handleDelete = (id, conceptId) => {
        props.handleDelete(id, conceptId, valuesRef, setValues, setAlert, onOpen)
    }

    if (error) {
        //Render Error State
        return <Error404 setTitle={props.setTitle} />
    }

    if (loading) {
        //Render Loading State
        return (
            <Flex padding="30px">
                <Spinner />
                <Flex marginLeft="10px">Loading Fields {loadingMessage}</Flex>
            </Flex>
        )
    }
    if (values.length < 1) {
        //Render Empty List State
        return (
            <Flex padding="30px">
                <Flex marginLeft="10px">No Fields Found</Flex>
            </Flex>
        )
    }
    else {
        return (
            <div>
                <CCBreadcrumbBar>
                    <Link href={"/"}>Home</Link>
                    <Link href={"/scanreports/"}>Scan Reports</Link>
                    <Link href={`/scanreports/${scanReportTable.current.scan_report}/`}>{scanReportName.current}</Link>
                    <Link href={`/scanreports/${scanReportTable.current.scan_report}/tables/${scanReportTableId}/`}>{scanReportTable.current.name}</Link>
                </CCBreadcrumbBar>
                <PageHeading text={"Fields"} />
                <Flex my="10px">
                    <HStack>
                        <Link href={"/scanreports/" + scanReportId + "/details/"}>
                            <Button variant="blue" my="10px">Scan Report Details</Button>
                        </Link>
                        <Link href={"/scanreports/" + scanReportId + "/mapping_rules/"}>
                            <Button isDisabled={mappingButtonDisabled} variant="blue" my="10px">Go to Rules</Button>
                        </Link>
                        {window.canEdit && <Link href={"/scanreports/" + scanReportId + "/tables/" + scanReportTableId + "/update/"}>
                            <Button variant="blue" my="10px">Edit Table</Button>
                        </Link>
                        }
                    </HStack>
                </Flex>
                {isOpen &&
                    <ScaleFade initialScale={0.9} in={isOpen}>
                        <ToastAlert hide={onClose} title={alert.title} status={alert.status} description={alert.description} />
                    </ScaleFade>
                }
                <Center>
                    <Pagination
                        activePage={currentPage}
                        itemsCountPerPage={page_size}
                        totalItemsCount={totalItemsCount}
                        pageRangeDisplayed={5}
                        onChange={onPageChange}
                        itemClass='btn paginate'
                        activeClass='btn disabled paginate'
                    />
                </Center>
                <Table variant="striped" colorScheme="greyBasic">
                    <TableCaption></TableCaption>
                    <Thead>
                        <Tr>
                            <Th>Field</Th>
                            <Th>Description</Th>
                            <Th>Data type</Th>
                            <Th>Concepts</Th>
                            <Th></Th>
                            {window.canEdit && <Th>Edit</Th>}
                        </Tr>
                    </Thead>
                    <Tbody>
                        {
                            // Create new row for every value object
                            values.map((item, index) =>
                                <Tr key={item.id}>
                                    <Td><Link style={{ color: "#0000FF", }} href={`/scanreports/${scanReportId}/tables/${scanReportTableId}/fields/${item.id}/`}>{item.name}</Link></Td>
                                    <Td maxW="250px"><Text maxW="100%" w="max-content">{item.description_column}</Text></Td>
                                    <Td>{item.type_column}</Td>

                                    <Td maxW="300px">
                                        {item.conceptsLoaded ?
                                            item.concepts.length > 0 &&
                                            <VStack alignItems='flex-start' >
                                                {item.concepts.map((concept) => (
                                                    <ConceptTag
                                                        key={concept.concept.concept_id}
                                                        conceptName={concept.concept.concept_name}
                                                        conceptId={concept.concept.concept_id.toString()}
                                                        conceptIdentifier={concept.id.toString()} itemId={item.id}
                                                        handleDelete={handleDelete}
                                                        creation_type={concept.creation_type ? concept.creation_type : undefined}
                                                        readOnly={!window.canEdit}
                                                    />
                                                ))}
                                            </VStack>
                                            :
                                            item.conceptsLoaded === false ?
                                                <Flex >
                                                    <Spinner />
                                                    <Flex marginLeft="10px">Loading Concepts</Flex>
                                                </Flex>
                                                :
                                                <Text>Failed to load concepts</Text>
                                        }
                                    </Td>
                                    <Td>

                                        <Formik initialValues={{ concept: '' }} onSubmit={(data, actions) => {
                                            handleSubmit(item.id, data.concept)
                                            actions.resetForm();
                                        }}>
                                            {({ values, handleChange, handleBlur, handleSubmit }) => (
                                                <Form onSubmit={handleSubmit}>
                                                    <HStack>
                                                        <Input
                                                            w={"105px"}
                                                            type='number'
                                                            name='concept'
                                                            value={values.concept}
                                                            onChange={handleChange}
                                                            onBlur={handleBlur}
                                                            isDisabled={!window.canEdit}
                                                        />
                                                        <div>
                                                            <Button type='submit' isDisabled={!window.canEdit} backgroundColor='#3C579E' color='white'>Add</Button>
                                                        </div>
                                                    </HStack>
                                                </Form>
                                            )}
                                        </Formik>
                                    </Td>
                                    {window.canEdit && <Td><Link style={{ color: "#0000FF", }} href={window.location.href + "fields/" + item.id + "/update/"}>Edit Field</Link></Td>}
                                </Tr>
                            )
                        }
                    </Tbody>
                </Table>
            </div>
        )

    }

}


export default FieldsTbl
